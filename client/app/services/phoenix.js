import Ember from 'ember';

import {Socket} from "../utils/phoenix";

export default Ember.Service.extend(Ember.Evented, {
  socket: null,

  setup: function() {
    this.socket = new Socket("/socket");
    this.socket.connect();
  }.on('init'),

  connect(user_id, token) {
    let chan = this.socket.channel("jsonapi:stream:" + user_id, {token: token});
    chan.join().receive("ok", () => {
      console.log("Connected to jsonapi:stream:*!");
    });

    let that = this;
    chan.on("new", function(data) {
      that.trigger('new', data);
    });
    chan.on("delete", function(data) {
      that.trigger('delete', data);
    });

    return this;
  }
});

