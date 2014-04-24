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
      error: new noflo.Port 'all'

    componentWire.forwardGroups this, 'in', 'out'
    componentWire.recordGroups this, 'in'

    @inPorts.in.on 'data', (data) =>
      if data == 'pass'
        @outPorts.out.send data
      if data == 'fail'
        @emitDataWithGroups 'error', @getGroups('in'), data


class TestAsyncComponent extends noflo.Component
  constructor: () ->
    @inPorts =
      in: new noflo.Port 'all'
    @outPorts =
      out: new noflo.Port 'all'
      error: new noflo.Port 'all'

    componentWire.recordGroups this, 'in'

    @inPorts.in.on 'data', (data) =>
      groups = @copyGroups 'in'
      setTimeout =>
        if data == 'pass'
          @emitDataWithGroups 'out', groups, data
        if data == 'fail'
          @emitDataWithGroups 'error', groups, data
      , 10

setupComponent = ->
  c = new TestComponent
  ins = socket.createSocket()
  out = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.in.attach ins
  c.outPorts.out.attach out
  c.outPorts.error.attach err
  return [c, ins, out, err]

setupAsyncComponent = ->
  c = new TestAsyncComponent
  ins = socket.createSocket()
  out = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.in.attach ins
  c.outPorts.out.attach out
  c.outPorts.error.attach err
  return [c, ins, out, err]

#
exports['test pass data & groups on sync component'] = (test) ->
  [c, ins, out, err] = setupComponent()
  out.once 'begingroup', (group) ->
    test.equal group, 'group1'
    out.once 'begingroup', (group) ->
      test.equal group, 'group2'
      out.once 'data', (data) ->
        test.equal data, 'pass'
        out.once 'endgroup', () ->
          test.ok true
          out.once 'endgroup', () ->
            test.ok true
            out.once 'disconnect', () ->
              test.ok true
              test.done()
  ins.beginGroup 'group1'
  ins.beginGroup 'group2'
  ins.send 'pass'
  ins.endGroup()
  ins.endGroup()
  ins.disconnect()

exports['test error & groups on sync component'] = (test) ->
  [c, ins, out, err] = setupComponent()
  err.once 'begingroup', (group) ->
    test.equal group, 'group1'
    err.once 'begingroup', (group) ->
      test.equal group, 'group2'
      err.once 'data', (data) ->
        test.equal data, 'fail'
        err.once 'endgroup', () ->
          test.ok true
          err.once 'endgroup', () ->
            test.ok true
            err.once 'disconnect', () ->
              test.ok true
              test.done()
  ins.beginGroup 'group1'
  ins.beginGroup 'group2'
  ins.send 'fail'
  ins.endGroup()
  ins.endGroup()
  ins.disconnect()

exports['test pass data & groups on async component'] = (test) ->
  [c, ins, out, err] = setupAsyncComponent()
  out.once 'begingroup', (group) ->
    test.equal group, 'group1'
    out.once 'begingroup', (group) ->
      test.equal group, 'group2'
      test.ok true
      out.once 'data', (data) ->
        test.equal data, 'pass'
        out.once 'endgroup', () ->
          test.ok true
          out.once 'endgroup', () ->
            test.ok true
            out.once 'disconnect', () ->
              test.ok true
              test.done()
  ins.beginGroup 'group1'
  ins.beginGroup 'group2'
  ins.send 'pass'
  ins.endGroup()
  ins.endGroup()
  ins.disconnect()

exports['test error & groups on async component'] = (test) ->
  [c, ins, out, err] = setupAsyncComponent()
  err.once 'begingroup', (group) ->
    test.equal group, 'group1'
    err.once 'begingroup', (group) ->
      test.equal group, 'group2'
      test.ok true
      err.once 'data', (data) ->
        test.equal data, 'fail'
        err.once 'endgroup', () ->
          test.ok true
          err.once 'endgroup', () ->
            test.ok true
            err.once 'disconnect', () ->
              test.ok true
              test.done()
  ins.beginGroup 'group1'
  ins.beginGroup 'group2'
  ins.send 'fail'
  ins.endGroup()
  ins.endGroup()
  ins.disconnect()
