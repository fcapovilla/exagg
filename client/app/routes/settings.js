import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    doSync() {
      Ember.$.getJSON('/api/sync', function(data) {
        // TODO: Refresh data without reload.
        window.location = window.location;
      });
    }
  }
});