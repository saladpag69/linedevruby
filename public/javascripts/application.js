import { Application } from "@hotwired/stimulus"
import CalculatorController from "./controllers/calculator_controller.js"

const application = Application.start()
application.register("calculator", CalculatorController)

window.Stimulus = application

// Auto-calculate on page load
document.addEventListener("DOMContentLoaded", () => {
  // Delay to ensure Stimulus is loaded
  setTimeout(() => {
    const app = window.Stimulus
    if (app && app.modules.has("calculator")) {
      const ctrl = app.modules.get("calculator")[0]
      if (ctrl) {
        ctrl.calculateArea()
        ctrl.calculateWall()
        ctrl.calculateVolume()
      }
    }
  }, 100)
})