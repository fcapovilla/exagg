import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    doSync() {
      var that = this;
      this.store.adapterFor('application').ajax('/api/sync').then(function(data) {
        that.store.pushPayload(data);
      });
    },

    onOpmlUpload(data) {
      this.store.pushPayload(data);
    }
  }
});
