"""Modelo financiero de Cadencia (Fase 5).

TODAS las cifras de entrada son HIPÓTESIS basadas en referencias públicas citadas en
INFORME_FASE5_Monetizacion.md. No son datos reales del juego (todavía no existe).

Uso:  python -I -X utf8 modelo_financiero.py  [carpeta_salida]
Genera resultados.md y resultados.csv en la carpeta de salida (por defecto, la del script).

Revisión del 17/11/2026 (decisión del cliente): se elimina el pago único «Sin anuncios» y los 10 temas
pasan al Club. Las compras únicas son ahora solo packs de fichas (1,99–3,99 €, ticket medio 2,5 €).
La conversión al Club se deja igual que antes, sin sumar el efecto de los temas: es la lectura prudente.
"""
import csv
import os
import sys

USD_EUR = 0.90          # hipótesis de tipo de cambio
NET_STORE = 0.85        # comisión de tienda del 15 % (Small Business Program / Google <1 M$)
VAT_BLEND = 1.12        # IVA medio incluido en el precio al consumidor (mezcla UE ~21 % y EE. UU. 0 %)
NET_FACTOR = NET_STORE / VAT_BLEND

PRICE_MONTHLY = 4.99    # € suscripción mensual (propuesta)
PRICE_ANNUAL = 29.99    # € suscripción anual (propuesta)

SCEN = {
    #             DAU/MAU, D1,  D7,   D30,  inter/DAU, rew/DAU, eCPM_int$, eCPM_rew$, %subs_MAU, %anual, %compra_unica_MAU/mes, ticket€, %DAU_premium
    "Conservador": dict(stick=0.15, d1=0.30, d7=0.08, d30=0.03, inter=2.0, rew=1.0, ecpm_i=4.0, ecpm_r=6.0,
                        subs=0.005, annual=0.5, one=0.002, ticket=2.5),
    "Intermedio": dict(stick=0.20, d1=0.38, d7=0.14, d30=0.06, inter=3.0, rew=1.5, ecpm_i=6.0, ecpm_r=9.0,
                       subs=0.010, annual=0.5, one=0.004, ticket=2.5),
    "Optimista": dict(stick=0.25, d1=0.45, d7=0.20, d30=0.10, inter=4.0, rew=2.0, ecpm_i=8.0, ecpm_r=12.0,
                      subs=0.020, annual=0.5, one=0.006, ticket=2.5),
}
DAUS = [1_000, 10_000, 50_000, 100_000]


def costs_month(dau, scen):
    """Costes operativos mensuales en € (hipótesis).
    - Apple Developer Program 99 $/año, Google Play 25 $ pago único (prorrateado en 12 meses el primer año).
    - Sin servidores propios (MVP sin backend); analítica y herramientas en planes gratuitos.
    - Autónomo (si aplica): ~80 €/mes con tarifa plana el primer año; se usa 300 €/mes como hipótesis prudente
      a partir de ese nivel de actividad. Gestoría: 50 €/mes. Confirmar con un gestor.
    - Servicios de terceros que podrían dejar de ser gratis al crecer (analítica, almacenamiento): 0 / 50 / 150 €.
    """
    stores = (99 + 25) * USD_EUR / 12
    autonomo = 300 if dau >= 10_000 else 80
    gestoria = 50
    terceros = 0 if dau < 50_000 else (50 if dau < 100_000 else 150)
    return stores + autonomo + gestoria + terceros


def retention(t, s):
    """Curva potencial r(t) = D1 * t^-b ajustada con D1 y D30 (t en días, t>=1)."""
    import math
    b = math.log(s["d1"] / s["d30"]) / math.log(30)
    return s["d1"] * t ** (-b)


def model(dau, s):
    mau = dau / s["stick"]
    subs = mau * s["subs"]
    prem_dau = min(dau, subs * 0.6)            # hipótesis: ~60 % de los suscriptores juega cada día
    ad_dau = dau - prem_dau
    imps_i = ad_dau * s["inter"] * 30
    imps_r = ad_dau * s["rew"] * 30
    ads = (imps_i * s["ecpm_i"] + imps_r * s["ecpm_r"]) / 1000 * USD_EUR
    sub_month_net = (s["annual"] * PRICE_ANNUAL / 12 + (1 - s["annual"]) * PRICE_MONTHLY) * NET_FACTOR
    subs_rev = subs * sub_month_net
    one_rev = mau * s["one"] * s["ticket"] * NET_FACTOR
    rev = ads + subs_rev + one_rev
    cost = costs_month(dau, s)
    arpdau = rev / (dau * 30)
    payers = subs + mau * s["one"]
    arppu = (subs_rev + one_rev) / payers if payers else 0
    ltv180 = arpdau * (1 + sum(retention(t, s) for t in range(1, 181)))
    return dict(DAU=dau, MAU=round(mau), suscriptores=round(subs), impresiones_mes=round(imps_i + imps_r),
                ingresos_anuncios=round(ads), ingresos_suscripcion=round(subs_rev), ingresos_compras=round(one_rev),
                ingresos_totales=round(rev), costes=round(cost), beneficio=round(rev - cost),
                ARPDAU=round(arpdau, 3), ARPPU=round(arppu, 2), LTV180=round(ltv180, 2),
                pct_anuncios=round(100 * ads / rev, 1) if rev else 0)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
    rows = []
    for name, s in SCEN.items():
        for d in DAUS:
            r = model(d, s)
            rows.append(dict(escenario=name, **r))
    with open(os.path.join(out, "resultados.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=rows[0].keys())
        w.writeheader()
        w.writerows(rows)
    lines = ["| Escenario | DAU | MAU | Suscriptores | Impresiones/mes | Anuncios €/mes | Suscripción €/mes | Compras €/mes | **Ingresos €/mes** | Costes €/mes | **Beneficio €/mes** | ARPDAU € | ARPPU €/mes | LTV 180 d € | % anuncios |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
    def es(x, dec=0):
        """Formato español: punto de miles y coma decimal."""
        s = f"{x:,.{dec}f}"
        return s.replace(",", "X").replace(".", ",").replace("X", ".")

    for r in rows:
        lines.append(f"| {r['escenario']} | {es(r['DAU'])} | {es(r['MAU'])} | {es(r['suscriptores'])} | {es(r['impresiones_mes'])} | "
                     f"{es(r['ingresos_anuncios'])} | {es(r['ingresos_suscripcion'])} | {es(r['ingresos_compras'])} | **{es(r['ingresos_totales'])}** | "
                     f"{es(r['costes'])} | **{es(r['beneficio'])}** | {es(r['ARPDAU'], 3)} | {es(r['ARPPU'], 2)} | {es(r['LTV180'], 2)} | {es(r['pct_anuncios'], 1)} |")
    txt = "\n".join(lines)
    open(os.path.join(out, "resultados.md"), "w", encoding="utf-8").write(txt + "\n")
    print(txt)


if __name__ == "__main__":
    main()
