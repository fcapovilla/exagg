import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.query('item', {filter: {favorite: true}, limit: 20});
  },

  setupController() {
    this.controllerFor('index').set('selectedElement', 'favorites');
  },

  renderTemplate: function(controller, model) {
    this.render('item-list', {
      controller: 'itemList',
      model: model
    });
  }
});
