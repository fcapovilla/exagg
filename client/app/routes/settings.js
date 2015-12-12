import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    doSync() {
      this.store.adapterFor('application').ajax('/api/sync').then(function(data) {
        // TODO: Refresh data without reload.
        window.location = window.location;
      });
    },

    onOpmlUpload(data) {
      this.store.pushPayload(data);
    }
  }
});
