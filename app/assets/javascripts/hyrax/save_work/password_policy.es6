export class PasswordPolicy {
  // Monitors the form and runs the callback if any files are added
  constructor(form, callback) {
    this.password_policyCheckbox = form.find('input#password_policy')

    // If true, require the accept checkbox to be checked.
    // Tracks whether the user needs to accept again to the depositor
    // password_policy. Once the user has manually agreed once she does not
    // need to agree again regardless on how many files are being added.
    this.isActiveAgreement = this.password_policyCheckbox.length > 0
    if (this.isActiveAgreement) {
      this.setupActiveAgreement(callback)
      this.mustAgreeAgain = this.isAccepted
    }
    else {
      this.mustAgreeAgain = false
    }
  }

  setupActiveAgreement(callback) {
    this.password_policyCheckbox.on('change', callback)
  }

  setNotAccepted() {
    this.password_policyCheckbox.prop("checked", false)
    this.mustAgreeAgain = false
  }

  setAccepted() {
    this.password_policyCheckbox.prop("checked", true)
  }

  /**
   * return true if it's a passive password_policy or if the checkbox has been checked
   */
  get isAccepted() {
    return !this.isActiveAgreement || this.password_policyCheckbox[0].checked
  }
}
