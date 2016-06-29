## Alchemy 

### GET /courses(.:format) 
#### Related Source Code
`render json: enrolled_courses, status: :ok`


### POST /courses(.:format) 
#### Related Source Code
`render json: @course, status: :created`
`render json: @course.errors, status: :unprocessable_entity`


### GET /courses/:id(.:format) 
#### Related Source Code
`render json: @course`


### PATCH /courses/:id(.:format) 
#### Related Source Code
`render json: @course, status: :ok`
`render json: @course.errors, status: :unprocessable_entity`


### PUT /courses/:id(.:format) 
#### Related Source Code
`render json: @course, status: :ok`
`render json: @course.errors, status: :unprocessable_entity`


### DELETE /courses/:id(.:format) 
#### Related Source Code
`render json: @course.errors, status: :unprocessable_entity`


### PUT /courses/:id/enroll(.:format) 
#### Related Source Code
`render json: enrollment.errors, status: :unprocessable_entity`
`render json: { error: "No course with that access code could be found" }, status: :not_found`


### GET /universities(.:format) 
#### Related Source Code
`render json: University.all`


### POST /universities(.:format) 
#### Related Source Code
No relevant source code


### GET /universities/new(.:format) 
#### Related Source Code
No relevant source code


### PATCH /universities/:id(.:format) 
#### Related Source Code
No relevant source code


### PUT /universities/:id(.:format) 
#### Related Source Code
No relevant source code


### GET /scenarios(.:format) 
#### Related Source Code
No relevant source code


### POST /scenarios(.:format) 
#### Related Source Code
`render json: @scenario, status: :created`
`render json: @scenario.errors, status: :unprocessable_entity`


### GET /scenarios/:id/edit(.:format) 
#### Related Source Code
No relevant source code


### GET /scenarios/:id(.:format) 
#### Related Source Code
No relevant source code


### PATCH /scenarios/:id(.:format) 
#### Related Source Code
No relevant source code


### PUT /scenarios/:id(.:format) 
#### Related Source Code
No relevant source code


### GET /users/sign_in(.:format) 
#### Related Source Code
`respond_with(resource, serialize_options(resource))`


### POST /users/sign_in(.:format) 
#### Related Source Code
`respond_with resource, location: after_sign_in_path_for(resource)`


### DELETE /users/sign_out(.:format) 
#### Related Source Code
No relevant source code


### POST /users/password(.:format) 
#### Related Source Code
`respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))`
`respond_with(resource)`


### GET /users/password/new(.:format) 
#### Related Source Code
No relevant source code


### GET /users/password/edit(.:format) 
#### Related Source Code
No relevant source code


### PATCH /users/password(.:format) 
#### Related Source Code
`respond_with resource, location: after_resetting_password_path_for(resource)`
`respond_with resource`


### PUT /users/password(.:format) 
#### Related Source Code
`respond_with resource, location: after_resetting_password_path_for(resource)`
`respond_with resource`


### GET /users/cancel(.:format) 
#### Related Source Code
No relevant source code


### POST /users(.:format) 
#### Related Source Code
`respond_with resource, location: after_sign_up_path_for(resource)`
`respond_with resource, location: after_inactive_sign_up_path_for(resource)`
`respond_with resource`


### GET /users/sign_up(.:format) 
#### Related Source Code
`respond_with self.resource`


### GET /users/edit(.:format) 
#### Related Source Code
`render :edit`


### PATCH /users(.:format) 
#### Related Source Code
`respond_with resource, location: after_update_path_for(resource)`
`respond_with resource`


### PUT /users(.:format) 
#### Related Source Code
`respond_with resource, location: after_update_path_for(resource)`
`respond_with resource`


### DELETE /users(.:format) 
#### Related Source Code
`respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }`


### PUT /users/elevate_to_instructor(.:format) 
#### Related Source Code
`render json: { failure: "User #{email} could not be found."}, status: 404 and return`
`render json: { failure: "User #{email} is already at or above instructor level."}, status: 400 and return`
`render json: { success: "User #{email} is now an instructor."}, status: 200 and return`

#### The following actions had routes defined but no implementation. 
CoursesController => new
CoursesController => edit
UniversitiesController => edit
UniversitiesController => show
UniversitiesController => destroy
ScenariosController => new
ScenariosController => destroy
