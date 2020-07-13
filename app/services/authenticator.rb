class Authenticator
  def initialize(staff)
    @staff = staff
  end

  def authenticate(raw_password)
    @staff && @staff.password_digest && BCrypt::Password.new(@staff.password_digest) == raw_password
  end
end
