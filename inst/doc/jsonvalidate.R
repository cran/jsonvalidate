## ----echo = FALSE, results = "hide"-------------------------------------------
knitr::opts_chunk$set(error = FALSE)

## -----------------------------------------------------------------------------
schema <- '{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Product",
    "description": "A product from Acme\'s catalog",
    "type": "object",
    "properties": {
        "id": {
            "description": "The unique identifier for a product",
            "type": "integer"
        },
        "name": {
            "description": "Name of the product",
            "type": "string"
        },
        "price": {
            "type": "number",
            "minimum": 0,
            "exclusiveMinimum": true
        },
        "tags": {
            "type": "array",
            "items": {
                "type": "string"
            },
            "minItems": 1,
            "uniqueItems": true
        }
    },
    "required": ["id", "name", "price"]
}'

## -----------------------------------------------------------------------------
obj <- jsonvalidate::json_schema$new(schema)

## -----------------------------------------------------------------------------
path <- tempfile()
writeLines(schema, path)
obj <- jsonvalidate::json_schema$new(path)

## ----include = FALSE----------------------------------------------------------
file.remove(path)

## -----------------------------------------------------------------------------
obj$validate("{}")

## -----------------------------------------------------------------------------
obj$validate("{}", verbose = TRUE)

## ----error = TRUE-------------------------------------------------------------
try({
obj$validate("{}", error = TRUE)
})

## -----------------------------------------------------------------------------
obj$validate('{
    "id": 1,
    "name": "A green door",
    "price": 12.50,
    "tags": ["home", "green"]
}')

## -----------------------------------------------------------------------------
obj$validate('{
    "id": 1,
    "name": "A green door",
    "price": -1,
    "tags": ["home", "green"]
}', verbose = TRUE)

## -----------------------------------------------------------------------------
obj$validate('{
    "id": 1,
    "name": "A green door",
    "price": 12.50,
    "tags": ["home", "home"]
}', verbose = TRUE)

## -----------------------------------------------------------------------------
obj$validate('{
    "id": "identifier",
    "name": 1,
    "price": -1,
    "tags": ["home", "home", 1]
}', verbose = TRUE)

## -----------------------------------------------------------------------------
json <- '{
    "id": 1,
    "name": "A green door",
    "price": 12.50,
    "tags": ["home", "green"]
}'
jsonvalidate::json_validate(json, schema, engine = "ajv")

## -----------------------------------------------------------------------------
v <- jsonvalidate::json_validator(schema, engine = "ajv")
v(json)

## -----------------------------------------------------------------------------
schema <- '{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {
    "city": { "type": "string" }
  },
  "type": "object",
  "properties": {
    "city": { "$ref": "#/definitions/city" }
  }
}'
json <- '{
    "city": "Firenze"
}'
jsonvalidate::json_validate(json, schema, engine = "ajv")

## -----------------------------------------------------------------------------
city_schema <- '{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "string",
  "enum": ["Firenze"]
}'
address_schema <- '{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type":"object",
  "properties": {
    "city": { "$ref": "city.json" }
  }
}'

path <- tempfile()
dir.create(path)
address_path <- file.path(path, "address.json")
city_path <- file.path(path, "city.json")
writeLines(address_schema, address_path)
writeLines(city_schema, city_path)
jsonvalidate::json_validate(json, address_path, engine = "ajv")

## -----------------------------------------------------------------------------
user_schema = '{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "required": ["address"],
  "properties": {
    "address": {
      "$ref": "sub/address.json"
    }
  }
}'

json <- '{
  "address": {
    "city": "Firenze"
  }
}'

path <- tempfile()
subdir <- file.path(path, "sub")
dir.create(subdir, showWarnings = FALSE, recursive = TRUE)
city_path <- file.path(subdir, "city.json")
address_path <- file.path(subdir, "address.json")
user_path <- file.path(path, "schema.json")
writeLines(city_schema, city_path)
writeLines(address_schema, address_path)
writeLines(user_schema, user_path)
jsonvalidate::json_validate(json, user_path, engine = "ajv")

