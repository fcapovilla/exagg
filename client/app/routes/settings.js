import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    doSync() {
      Ember.$.getJSON('/sync', function(data) {
        //TODO: Check the server's response.
      });
    }
  }
});
