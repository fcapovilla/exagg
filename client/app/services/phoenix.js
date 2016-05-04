import Ember from 'ember';

import {Socket} from "../utils/phoenix";

export default Ember.Service.extend(Ember.Evented, {
  socket: null,

  setup: function() {
    this.socket = new Socket("/socket");
    this.socket.connect();
  }.on('init'),

  connect(token) {
    let chan = this.socket.channel("items:stream", {token: token});
    chan.join().receive("ok", () => {
      console.log("Connected to items:stream!");
    });

    let that = this;
    chan.on("new:items", function() {
      that.trigger('newItems');
    });

    return this;
  }
});

