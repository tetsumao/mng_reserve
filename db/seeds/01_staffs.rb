[
  {login_name: 'admin', password: 'admin', staff_name: '管理者', dspo: 1},
].each do |record|
  begin
    Staff.create!(record)
  rescue => e
    puts record
    puts e
    raise e
  end
end
