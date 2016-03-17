import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.findAll('user');
  },

  actions: {
    doSync() {
      var that = this;
      this.store.adapterFor('application').ajax('/api/sync').then(function(data) {
        that.store.pushPayload(data);
      });
    },

    onOpmlUpload(data) {
      this.store.pushPayload(data);
    },

    onFavoritesUpload(data) {
      this.store.pushPayload(data);
    },

    onItemsUpload(data) {
      this.store.pushPayload(data);
    }
  }
});
