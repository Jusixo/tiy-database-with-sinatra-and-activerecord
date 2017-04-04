require 'sinatra'
require 'pg'
require 'sinatra/reloader' if development?

get '/' do
  erb :home
end

get '/employees' do
  database = PG.connect(dbname: "tiy-database")
  @accounts = database.exec("SELECT * FROM employees")

  erb :employees
end

get '/employee' do
  select_employee = params["name"]

  database = PG.connect(dbname: "tiy-database")
  @people = database.exec("SELECT * FROM employees WHERE name = $1", [select_employee])

  erb :employee_page
end

get '/new_employee' do
  erb :new_employee
end

get '/create_employee' do
  name = params["name"]
  phone = params["phone"]
  address = params["address"]
  position = params["position"]
  salary.to_i = params["salary"]
  slack = params["slack"]
  github = params["guthub"]

  database = PG.connect(dbname: "tiy-database")
  @accounts = database.exec("INSERT INTO employees(name, phone, address, position, salary, github, slack) VALUES($1, $2, $3, $4, $5, $6, $7)", [name, phone, address, position, salary, github, slack])

  redirect to("/")
end

get '/search_results' do
  which_employee = params["search_param"]

  database = PG.connect(dbname: "tiy-database")
  @people = database.exec("SELECT * FROM employees WHERE name = $1 OR github = $1 OR slack = $1 OR name LIKE $1", ["%#{which_employee}%"])

  erb :employee
end

get '/edit_employee' do
  id = params["id"]

  database = PG.connect(dbname: "tiy-database")
  people = database.exec("SELECT * FROM employees WHERE id = $1", [id])

  @person = people.first

  erb :edit_employee
end

get '/update_employee' do
  name = params["name"]
  phone = params["phone"]
  address = params["address"]
  position = params["position"]
  salary.to_i = params["salary"]
  github = params["github"]
  slack = params["slack"]
  id = params["id"]

  database = PG.connect(dbname: "tiy-database")

  @people = database.exec("UPDATE employees SET name = $1, phone = $2, address = $3, position = $4, salary = $5, github = $6, slack = $7 WHERE id = $8", [name, phone, address, position, salary, github, slack, id])

  redirect to("/employees")
end

get '/delete_employee' do
  id = params["id"]

  database = PG.connect(dbname: "tiy-database")

  @people = database.exec("DELETE FROM employees WHERE id = $1", [id])

  redirect to("/employees")
end
