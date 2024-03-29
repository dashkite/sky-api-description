import * as Meta from "@dashkite/joy/metaclass"
import * as URLCodex from "@dashkite/url-codex"

import { Resource } from "./resource"

class Description

  Meta.mixin @::, [

    Meta.getters
      data: -> @_
      entries: ->
        for name, resource of @_.resources
          Resource.from { name, resource }
      resources: ->
        new Proxy @_.resources,
          get: ( target, name, self ) ->
            Resource.from { name, resource: ( Reflect.get target, name, self ) }

  ]

  [ Symbol.iterator ]: -> @entries[ Symbol.iterator ]()

  @discover: ({ domain, lambda }) ->
    response = await Sky.fetch {
      domain, lambda
      resource: { name: "description" }
      method: "get"
      headers: accept: [ "application/json" ]
    }
    if response.description == "ok"
      @from response.content

  @from: ( value ) ->
    Object.assign ( new @ ),
      _: if value.request?
          { request } = value
          do -> await @discover request
        else if value.resources?
          value

  @decode: ( request ) ->
    ( await @from { request })
      .decode request
    
  # TODO support matching against full URL
  decode: ({ target }) ->
    for { name, templates } in @entries
      for template in templates
        if ( bindings = URLCodex.match template, target )?
          return { name, bindings }
  
export {
  Description
}
