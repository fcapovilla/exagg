import Ember from 'ember';

export default Ember.Route.extend({
  filters: Ember.inject.service('item-filters'),

  filterUpdate: Ember.observer('filters.read', function() {
    this.refresh();
  }),

  model() {
    this.store.unloadAll('item');

    return this.store.peekAll('item');
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.get('filters').selectModel('favorites');
  },

  renderTemplate(controller, model) {
    this.render('item-list', {
      model: model
    });
  }
});
