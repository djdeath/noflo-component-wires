componentWire = require '../src/index'
noflo = require 'noflo'
socket = noflo.internalSocket

#
class TestComponent extends noflo.Component
  constructor: () ->
    @inPorts =
      in: new noflo.Port 'all'
    @outPorts =
      out: new noflo.Port 'all'
    componentWire.forwardGroups this, 'in', 'out'
    @inPorts.in.on 'data', (data) =>
      @outPorts.out.send data

setupComponent = ->
  c = new TestComponent
  ins = socket.createSocket()
  out = socket.createSocket()
  c.inPorts.in.attach ins
  c.outPorts.out.attach out
  return [c, ins, out]

#
exports['test forward ports'] = (test) ->
  [c, ins, out] = setupComponent()
  out.once 'begingroup', (group) ->
    test.equal group, 'group'
  out.once 'data', (data) ->
    test.equal data, 'data'
  out.once 'endgroup', () ->
    test.ok true
  out.once 'disconnect', () ->
    test.ok true
    test.done()
  ins.send 'data'
  ins.disconnect()
