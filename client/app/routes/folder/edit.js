import Ember from 'ember';

export default Ember.Route.extend({
  filters: Ember.inject.service('item-filters'),

  model(params) {
    return this.store.findRecord('folder', params.folder_id);
  },

  setupController(controller, feed) {
    this._super(controller, feed);
    this.set('filters.selectedElement', feed);
  }
});
