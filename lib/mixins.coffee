_.mixin
  flatErrors: (errors) ->
    return Array.prototype.concat.apply([], _.values(errors))

  presenceOf: (field, message) ->
    (doc) ->
      value = _.nestedValue(doc, field)
      if _.isUndefined(value) or _.isBlank(value)
        return {} =
          field: field,
          message: if message then message else _.humanize(field.replace(".", " ")) + " cannot be blank"


  isOneOfOf: (field, values, message) ->
    (doc) ->
      value = _.nestedValue(doc, field)
      unless _.contains(values, value)
        return {} =
          field: field,
          message: if message then message else "Wrong value for #{_.capitalize(field)}"

  lengthOf: (field, options) ->
    (doc) ->
      value = _.nestedValue(doc, field) or ""
      if value and options.lte and options.gte and (value.length > options.lte or value.length < options.gte)
        message = _.humanize(field.replace(".", " ")) + " must be between " + options.gte + " and " + options.lte + " characters"
        if options.message
          message = options.message
        return {} =
          field: field,
          message: message

  isArrayOf: (field, options) ->
    (doc) ->
      value = _.nestedValue(doc, field) or ""
      if value and options.lte and options.gte and (value.length > options.lte or value.length < options.gte)
        message = _.humanize(field.replace(".", " ")) + " must be between " + options.gte + " and " + options.lte + " elements"
        if options.message
          message = options.message
        return {} =
          field: field,
          message: message