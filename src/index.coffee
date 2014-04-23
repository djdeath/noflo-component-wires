exports.forwardGroups = (component, src, dst) ->
  component.inPorts[src].on 'begingroup', (group) ->
    return unless component.outPorts[dst].isAttached()
    component.outPorts[dst].beginGroup group
  component.inPorts[src].on 'endgroup', () ->
    return unless component.outPorts[dst].isAttached()
    component.outPorts[dst].endGroup()
  component.inPorts[src].on 'disconnect', () ->
    return unless component.outPorts[dst].isConnected()
    component.outPorts[dst].disconnect()

exports.gatherInputs = (component, inputs, callback) ->
  component._inputs = {}

  component._checkInputs = () ->
    for name in inputs
      return unless @_inputs[name]?
    callback @_inputs

  connectInput = (c, n) ->
    c._inputs[n] = null
    c.inPorts[n].on 'data', (data) ->
      c._inputs[n] = data
      c._checkInputs()
    c.inPorts[n].on 'disconnect', () ->
      c._inputs[n] = null

  for name in inputs
    connectInput component, name
