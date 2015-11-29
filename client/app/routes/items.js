import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.query('item', {limit: 20});
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.controllerFor('index').set('selectedElement', 'items');
  },

  renderTemplate: function() {
    this.render('item-list');
  }
});
