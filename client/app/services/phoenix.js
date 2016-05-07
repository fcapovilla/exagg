import Ember from 'ember';

import {Socket} from "../utils/phoenix";

export default Ember.Service.extend(Ember.Evented, {
  socket: null,

  setup: function() {
    this.socket = new Socket("/socket");
    this.socket.connect();
  }.on('init'),

  connect(token) {
    let chan = this.socket.channel("jsonapi:stream", {token: token});
    chan.join().receive("ok", () => {
      console.log("Connected to jsonapi:stream!");
    });

    let that = this;
    chan.on("new:items", function(data) {
      that.trigger('newData', data);
    });
    chan.on("new:folders", function(data) {
      that.trigger('newData', data);
    });
    chan.on("new:feeds", function(data) {
      that.trigger('newData', data);
    });

    return this;
  }
});

