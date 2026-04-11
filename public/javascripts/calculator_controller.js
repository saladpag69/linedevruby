// Calculator Controller for Stimulus
(function() {
  'use strict'
  
  class CalculatorController extends Stimulus.Controller {
    static targets = [
      "areaValue", "areaForm", "selectedShape",
      "wallList", "wallValue", "wallDetails",
      "volLength", "volWidth", "volHeight", "volRatio",
      "volumeValue", "cementValue", "sandValue", "gravelValue"
    ]

    connect() {
      console.log("Calculator controller connected!")
      this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ""
      this.calculateArea()
      this.calculateWall()
      this.calculateVolume()
    }

    calculateArea() {
      if (!this.hasAreaFormTarget) return
      
      const formData = new FormData(this.areaFormTarget)
      const data = { shape: this.selectedShapeTarget?.value || "rectangle" }
      
      formData.forEach((value, key) => { data[key] = value })

      for (let key in data) {
        if (key !== "shape" && parseFloat(data[key]) < 0) {
          if (this.hasAreaValueTarget) this.areaValueTarget.textContent = "0"
          return
        }
      }

      fetch("/calculator/calculate_area", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({ area: data })
      })
      .then(res => res.json())
      .then(data => {
        if (this.hasAreaValueTarget) {
          this.areaValueTarget.textContent = data.area?.toFixed(2) || "0"
        }
      })
      .catch(err => console.error("Area calc error:", err))
    }

    calculateWall() {
      const walls = this.getWallData()
      if (walls.length === 0) return

      fetch("/calculator/calculate_wall", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({ walls: walls })
      })
      .then(res => res.json())
      .then(data => {
        if (this.hasWallValueTarget) {
          this.wallValueTarget.textContent = data.total_area?.toFixed(2) || "0"
        }
        if (this.hasWallDetailsTarget && data.walls) {
          this.wallDetailsTarget.innerHTML = data.walls.map((w, i) => 
            `<div class="detail-row"><span>Wall ${i+1}:</span><span>${w.paintable_area?.toFixed(2)} ตร.ม.</span></div>`
          ).join("")
        }
      })
      .catch(err => console.error("Wall calc error:", err))
    }

    getWallData() {
      const walls = []
      if (!this.hasWallListTarget) return walls
      
      this.wallListTarget.querySelectorAll('.wall-item').forEach(wall => {
        walls.push({
          width: wall.querySelector('input[name*="[width]"]')?.value || 0,
          height: wall.querySelector('input[name*="[height]"]')?.value || 0,
          door_width: wall.querySelector('input[name*="[door_width]"]')?.value || 0,
          door_height: wall.querySelector('input[name*="[door_height]"]')?.value || 0,
          door_count: wall.querySelector('input[name*="[door_count]"]')?.value || 0
        })
      })
      return walls
    }

    calculateVolume() {
      if (!this.hasVolLengthTarget || !this.hasVolWidthTarget || !this.hasVolHeightTarget) return
      
      const data = {
        length: this.volLengthTarget.value,
        width: this.volWidthTarget.value,
        height: this.volHeightTarget.value,
        ratio: this.volRatioTarget?.value || "1:2:4"
      }

      if (parseFloat(data.length) < 0 || parseFloat(data.width) < 0 || parseFloat(data.height) < 0) {
        if (this.hasVolumeValueTarget) this.volumeValueTarget.textContent = "0"
        return
      }

      fetch("/calculator/calculate_volume", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify(data)
      })
      .then(res => res.json())
      .then(data => {
        if (this.hasVolumeValueTarget) {
          this.volumeValueTarget.textContent = data.volume?.toFixed(3) || "0"
        }
        if (this.hasCementValueTarget) {
          this.cementValueTarget.textContent = (data.materials?.cement_bags || 0) + " ถุง"
        }
        if (this.hasSandValueTarget) {
          this.sandValueTarget.textContent = (data.materials?.sand || 0).toFixed(3) + " ลบ.ม."
        }
        if (this.hasGravelValueTarget) {
          this.gravelValueTarget.textContent = (data.materials?.gravel || 0).toFixed(3) + " ลบ.ม."
        }
      })
      .catch(err => console.error("Volume calc error:", err))
    }

    selectShape(event) {
      event.preventDefault()
      const shape = event.currentTarget.dataset.shape
      if (this.selectedShapeTarget) this.selectedShapeTarget.value = shape
      
      document.querySelectorAll('.shape-option[data-shape]').forEach(el => el.classList.remove('selected'))
      event.currentTarget.classList.add('selected')
      
      document.querySelectorAll('.shape-inputs').forEach(el => el.style.display = 'none')
      const inputsDiv = document.getElementById('inputs-' + shape)
      if (inputsDiv) inputsDiv.style.display = 'block'
      
      console.log("Shape selected:", shape)
      this.calculateArea()
    }

    selectRatio(event) {
      event.preventDefault()
      const ratio = event.currentTarget.dataset.ratio
      if (this.volRatioTarget) this.volRatioTarget.value = ratio
      
      document.querySelectorAll('.shape-option[data-ratio]').forEach(el => el.classList.remove('selected'))
      event.currentTarget.classList.add('selected')
      
      console.log("Ratio selected:", ratio)
      this.calculateVolume()
    }
  }

  // Register function called from onload
  window.registerCalculatorController = function() {
    if (window.Stimulus) {
      console.log("Stimulus loaded, registering controller...")
      window.Stimulus.register("calculator", CalculatorController)
    } else {
      console.error("Stimulus not available!")
    }
  }

  // Auto-register when script loads if Stimulus already exists
  if (window.Stimulus) {
    console.log("Stimulus already loaded, registering controller...")
    window.Stimulus.register("calculator", CalculatorController)
  } else {
    console.log("Waiting for Stimulus to load...")
  }
})()