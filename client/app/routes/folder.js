import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return Ember.RSVP.hash({
      folder: this.store.peekRecord('folder', params.folder_id),
      items: this.store.query('item', {folder_id: params.folder_id, limit: 20})
    });
  },

  setupController(controller, model) {
    this._super(controller, model.items);
    this.controllerFor('index').set('selectedElement', model.folder);
  }
});
