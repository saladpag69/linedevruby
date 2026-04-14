import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "width", "length", "thickness", "height", "depth", "preview", "formula", "area", "volume", "labor", "submitBtn"]
  static values = { serviceType: String, laborRate: Number }

  connect() {
    this.prices = window.siamCosmoPrices || []
  }

  calculate() {
    const width = parseFloat(this.widthTarget?.value) || 0
    const length = parseFloat(this.lengthTarget?.value) || 0
    const thickness = parseFloat(this.thicknessTarget?.value) || 0.10
    const height = parseFloat(this.heightTarget?.value) || 0
    const depth = parseFloat(this.depthTarget?.value) || 0

    if (width > 0 && length > 0) {
      const area = width * length
      const volume = this.calculateVolume(area, thickness, height, depth)

      this.updatePreview(area, volume)
      this.submitBtnTarget.disabled = false
    } else {
      this.formulaTarget.textContent = "กรุณาใส่ขนาดพื้นที่"
      this.areaTarget.textContent = "- ตร.ม."
      this.volumeTarget.textContent = "- ลบ.ม."
      this.laborTarget.textContent = "฿0"
      this.submitBtnTarget.disabled = true
    }
  }

  calculateVolume(area, thickness, height, depth) {
    const serviceType = this.element.dataset.serviceType || ""

    switch (serviceType) {
      case "concrete_floor":
        return area * thickness
      case "brick_wall":
        return area * thickness
      case "paint_wall":
        return area
      case "tile_floor":
        return area
      case "plumbing":
        return height || 0
      default:
        return area * Math.max(thickness, depth, height || 0)
    }
  }

  updatePreview(area, volume) {
    const serviceType = this.element.dataset.serviceType || ""
    const laborRate = parseFloat(this.element.dataset.laborRate) || 150

    let formulaText = ""
    let areaText = `${area.toFixed(2)} ตร.ม.`
    let volumeText = `${volume.toFixed(2)} ลบ.ม.`
    let laborTotal = 0

    switch (serviceType) {
      case "concrete_floor":
        formulaText = `ปริมาตร = ${area.toFixed(2)} × ${parseFloat(this.thicknessTarget?.value || 0.10).toFixed(2)}`
        laborTotal = area * laborRate
        break
      case "brick_wall":
        formulaText = `ปริมาตร = ${area.toFixed(2)} × ${parseFloat(this.thicknessTarget?.value || 0.10).toFixed(2)}`
        laborTotal = area * laborRate
        break
      case "paint_wall":
        formulaText = `พื้นที่ = ${area.toFixed(2)} (กว้าง × ยาว × สูง)`
        volumeText = "-"
        laborTotal = area * laborRate
        break
      case "tile_floor":
        formulaText = `พื้นที่ = ${area.toFixed(2)} (กว้าง × ยาว)`
        volumeText = "-"
        laborTotal = area * laborRate
        break
      default:
        formulaText = `พื้นที่ = ${area.toFixed(2)} × ...`
        laborTotal = area * laborRate
    }

    this.formulaTarget.textContent = formulaText
    this.areaTarget.textContent = areaText
    this.volumeTarget.textContent = volumeText
    this.laborTarget.textContent = `฿${Math.round(laborTotal).toLocaleString()}`
  }

  async previewMaterials() {
    const formData = new FormData(this.formTarget)
    const params = new URLSearchParams(formData)

    try {
      const response = await fetch(`/calculator/preview?${params}`, {
        method: "GET",
        headers: {
          "Accept": "application/json"
        }
      })

      if (response.ok) {
        return await response.json()
      }
    } catch (error) {
      console.error("Preview error:", error)
    }

    return null
  }
}
