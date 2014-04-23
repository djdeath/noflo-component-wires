componentWire = require '../src/index'
noflo = require 'noflo'
socket = noflo.internalSocket

#
class TestComponent extends noflo.Component
  constructor: () ->
    @inPorts =
      in: new noflo.Port 'all'
      data1: new noflo.Port 'all'
      data2: new noflo.Port 'all'
      data3: new noflo.Port 'all'
    @outPorts =
      out: new noflo.Port 'all'
    componentWire.gatherInputs this
      , ['in', 'data1', 'data2', 'data3']
      , (inputs) =>
        @outPorts.out.send(inputs.in + inputs.data1 + inputs.data2 + inputs.data3)
    componentWire.forwardGroups this, 'in', 'out'

setupComponent = ->
  c = new TestComponent
  ins = socket.createSocket()
  data1 = socket.createSocket()
  data2 = socket.createSocket()
  data3 = socket.createSocket()
  out = socket.createSocket()
  c.inPorts.in.attach ins
  c.inPorts.data1.attach data1
  c.inPorts.data2.attach data2
  c.inPorts.data3.attach data3
  c.outPorts.out.attach out
  return [c, ins, data1, data2, data3, out]

#
exports['test gathering inputs'] = (test) ->
  [c, ins, data1, data2, data3, out] = setupComponent()
  out.once 'begingroup', (group) ->
    test.ok true
    out.once 'data', (data) ->
      test.equal data, 'in123'
      out.once 'endgroup', () ->
        test.ok true
        out.once 'disconnect', () ->
          test.ok true
          test.done()
  ins.beginGroup 'group'
  ins.send 'in'
  data1.send '1'
  data2.send '2'
  data3.send '3'
  ins.endGroup()
  ins.disconnect()
