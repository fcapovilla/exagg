import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.query('item', {filter: {favorite: true}});
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.controllerFor('index').set('selectedElement', 'favorites');
  }
});
