import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "width",

    "length",
    "height",
    "concret",
    "area",
    "volume",
    "mesh",
    "totalPrice",
    "materialCost",
    "laborCost",
    "transportCost",
    "pricePerSqm",
    "priceRange",
  ];

  connect() {
    console.log("✅ Stimulus Calculator connected!");
    this.calculate();
  }

  calculate() {
    const w = parseFloat(this.widthTarget?.value) || 0;
    const l = parseFloat(this.lengthTarget?.value) || 0;
    const h = parseFloat(this.heightTarget?.value) || 0.15;

    const area = w * l;
    const volume = area * h;
    const laborRate = 150;
    const meshPrice = 30;
    const transportFee = 1500;

    const laborTotal = area * laborRate;
    const meshTotal = area * meshPrice;
    const transport = volume >= 5 ? transportFee : 0;
    const total = laborTotal + meshTotal + transport;
    const pricePerSqm = area > 0 ? total / area : 0;

    if (this.hasAreaTarget)
      this.areaTarget.textContent = area > 0 ? area.toFixed(2) + " ตร.ม." : "-";
    if (this.hasVolumeTarget)
      this.volumeTarget.textContent =
        volume > 0 ? volume.toFixed(2) + " ลบ.ม." : "-";
    
    if (this.hasMeshTarget)
      this.meshTarget.textContent = area > 0 ? area.toFixed(2) + " ตร.ม." : "-";
    if (this.hasLaborCostTarget)
      this.laborCostTarget.textContent =
        "฿" + Math.round(laborTotal).toLocaleString();
    if (this.hasMaterialCostTarget)
      this.materialCostTarget.textContent =
        "฿" + Math.round(meshTotal).toLocaleString();
    if (this.hasTransportCostTarget)
      this.transportCostTarget.textContent = "฿" + transport;
    if (this.hasTotalPriceTarget)
      this.totalPriceTarget.textContent =
        "฿" + Math.round(total).toLocaleString();
    if (this.hasPricePerSqmTarget)
      this.pricePerSqmTarget.textContent =
        area > 0 ? "฿" + pricePerSqm.toFixed(2) : "฿0";
    if (this.hasPriceRangeTarget)
      this.priceRangeTarget.textContent =
        total > 0
          ? "฿" +
            Math.round(total * 0.9).toLocaleString() +
            " - ฿" +
            Math.round(total * 1.1).toLocaleString()
          : "-";

    console.log("📐 Calculated:", { area, volume, total });
  }
}
