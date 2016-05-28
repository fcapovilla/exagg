import Ember from 'ember';

export default Ember.Route.extend({
  filters: Ember.inject.service('item-filters'),

  filterUpdate: Ember.observer('filters.read', function() {
    this.refresh();
  }),

  model(params) {
    this.store.unloadAll('item');

    return Ember.RSVP.hash({
      folder: this.store.peekRecord('folder', params.folder_id),
      items: this.store.peekAll('item')
    });
  },

  setupController(controller, model) {
    this._super(controller, model.items);
    this.get('filters').selectModel(model.folder);
    this.send('loadMore');
  },

  renderTemplate(controller, model) {
    this.render('item-list', {
      model: model.items
    });
  },
});
