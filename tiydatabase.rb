require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "tiy-database"
)

class Employee < ActiveRecord::Base
  validates :name, presence: true
  validates :salary, presence: true
  validates :github, length: { minimum: 5 }
  validates :position, inclusion: { in: %w{Instructor Student}, message: "%{value} must be Instructor or Student" }

  self.primary_key = "id"
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :home
end

get '/employees' do
  @employees = Employee.all

  erb :employees
end

get '/employee_show' do
  @employee = Employee.find(params["id"])
  if @employee
    erb :employee_show
  else
    erb :no_employee_found
  end
end

get '/new_employees' do
  @employee = Employee.new

  erb :new
end

get '/new' do
  @employee = Employee.create(params)
  if @employee.valid?
    redirect('/')
  else
    erb :new
  end
end

get '/search' do
  search = params["search"]

  @employees = Employee.where("name like ? or github = ? or slack = ?", "%#{search}%", search, search)

  erb :search
end

get '/edit_employee' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  erb :edit_employee
end

get '/update' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])
  @employee.update_attributes(params)

  if @employee.valid?
    redirect to("/employee_show?id=#{@employee.id}")
  else
    erb :edit_employee
  end
end

get '/delete' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  @employee.destroy

  redirect('/employees')
end
