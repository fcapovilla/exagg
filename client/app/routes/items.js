import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.query('item', {limit: 20});
  },

  setupController() {
    this.controllerFor('index').set('selectedElement', 'items');
  },

  renderTemplate: function(controller, model) {
    this.render('item-list', {
      controller: 'itemList',
      model: model
    });
  }
});
