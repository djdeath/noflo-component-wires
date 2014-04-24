#
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

#
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

#
exports.recordGroups = (component, input) ->
  component._groups = {}

  component.emitDataWithGroups = (input, output, data) ->
    port = @outPorts[output]
    return unless port.isAttached()
    for group in @_groups[input]
      port.beginGroup group
    port.send data
    for group in @_groups[input]
      port.endGroup()
    port.disconnect()

  component._groups[input] = []
  component.inPorts[input].on 'begingroup', (group) ->
    component._groups[input].push group
  component.inPorts[input].on 'endgroup', () ->
    component._groups[input].pop()
  component.inPorts[input].on 'disconnect', () ->
    component._groups[input] = []
