import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('folder', params.folder_id);
  },

  setupController(controller, feed) {
    this._super(controller, feed);
    this.controllerFor('index').set('selectedElement', feed);
  }
});