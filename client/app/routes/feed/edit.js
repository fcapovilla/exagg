import Ember from 'ember';

export default Ember.Route.extend({
  filters: Ember.inject.service('item-filters'),

  model(params) {
    return this.store.findRecord('feed', params.feed_id);
  },

  setupController(controller, feed) {
    this._super(controller, feed);
    this.get('filters').selectModel(feed);
  }
});
