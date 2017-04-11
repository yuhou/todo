require "./todo"
require "./list"

module Todo::Exec
  extend self
  private def copy_task(task, list_to)
    list_to << task
    list_to.save
  end

  def run(mode, date, id, list_name, dir_name, msg, sort)
    # new list
    list = List.new(list_name, dir_name)
    list.load(dir_name)

    # effect
    case mode
    when :add
      todo = ::Todo::Todo.new(msg, date)
      list << todo
      puts "ADD [#{list.size - 1}] #{todo.date} #{todo.msg}"
    when :list
      display = [] of Array(String)
      list.each_with_index { |todo, idx| display << [todo.date, "#{idx.to_s.rjust(4, ' ')} #{todo.date.rjust(12, ' ')} #{todo.msg}"] }
      display.sort_by! { |e| e[0] } if sort == :date
      puts display.map { |e| e[1] }.join("\n")
    when :rm
      todo = list[id]
      list.rm(id)
      puts "RM [#{id}] #{todo.msg}"
    when :update
      todo = list[id]
      list[id].msg = msg unless msg.empty?
      list[id].date = date
      puts "UP [#{id}] = (#{list[id].date}) #{list[id].msg}"
    when :archive
      todo = list[id]
      copy_task(todo, List.new("archives", dir_name).load)
      list.rm(id)
      puts "ARCHIVE [#{id}] #{todo.msg}"
    when :clear_all
      list.clear
    else
      puts "Error"
    end

    list.save(dir_name)
  end
end