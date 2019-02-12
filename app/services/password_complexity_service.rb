class PasswordComplexityService

  attr_reader :password, :required_complexity

  def initialize(password, required_complexity)
    @password = password
    @required_complexity = required_complexity
  end

  def valid?
    score = has_uppercase_letters? + has_digits? + has_extra_chars? + has_downcase_letters?
    score >= required_complexity
  end

  private

  # at least 1 uppercase letter
  def has_uppercase_letters?
    password.match(/[A-Z]/) ? 1 : 0
  end

  # at least 1 digit
  def has_digits?
    password.match(/\d/) ? 1 : 0
  end

  # at least 1 special character
  def has_extra_chars?
    password.match(/\W/) ? 1 : 0
  end

  # minimum of 3 lower case letters
  def has_downcase_letters?
    password.match(/[a-z]{3}/) ? 1 : 0
  end
end
