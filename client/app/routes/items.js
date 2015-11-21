import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.findAll('item');
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.controllerFor('index').set('selectedElement', 'items');
  }
});
