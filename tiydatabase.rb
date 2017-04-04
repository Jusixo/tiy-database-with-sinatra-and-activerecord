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

get '/employee_page' do
  @employee = Employee.find(params["id"])
  if @employee
    erb :employee_page
  else
    erb :no_employee_found
  end
end

get '/new' do
  erb :new
end

get '/new_employees' do
  Employee.create(params)

  redirect('/')
end

get '/search' do
  search = params["search"]

  @employees = Employee.where("name like $1 or github = $2 or slack = $2", "%#{search}%", search)

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

  erb :employee_page
end

get '/delete' do
  database = PG.connect(dbname: "tiy-database")

  @employee = Employee.find(params["id"])

  @employee.destroy

  redirect('/employees')
end
