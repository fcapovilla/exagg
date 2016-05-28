import Ember from 'ember';

export default Ember.Route.extend({
  filters: Ember.inject.service('item-filters'),

  filterUpdate: Ember.observer('filters.read', function() {
    this.refresh();
  }),

  model(params) {
    this.store.unloadAll('item');

    return Ember.RSVP.hash({
      feed: this.store.peekRecord('feed', params.feed_id),
      items: this.store.peekAll('item')
    });
  },

  setupController(controller, model) {
    this._super(controller, model.items);
    this.get('filters').selectModel(model.feed);
  },

  renderTemplate(controller, model) {
    this.render('item-list', {
      model: model.items
    });
  }
});
