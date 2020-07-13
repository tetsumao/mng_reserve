[
  {item_name: 'USBメモリ', stock: 10, description: '持出用USBメモリ', dspo: 1},
  {item_name: 'LANケーブル', stock: 5, description: '持出用LANケーブル', dspo: 2},
  {item_name: 'PCケース', stock: 3, description: 'ノートPC収納用PCケース', dspo: 3},
].each do |record|
  begin
    Item.create!(record)
  rescue => e
    puts record
    puts e
    raise e
  end
end
