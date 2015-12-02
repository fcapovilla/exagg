import Ember from 'ember';
import InfinityRoute from 'ember-infinity/mixins/route';

export default Ember.Route.extend(InfinityRoute, {
  perPageParam: "page_size",

  model(params) {
    return Ember.RSVP.hash({
      feed: this.store.peekRecord('feed', params.feed_id),
      items: this.infinityModel('item', {perPage: 20, startingPage: 1, feed_id: params.feed_id})
    });
  },

  setupController(controller, model) {
    this._super(controller, model.items);
    this.controllerFor('index').set('selectedElement', model.feed);
  },

  renderTemplate: function(controller, model) {
    this.render('item-list', {
      controller: 'itemList',
      model: model.items
    });
  }
});
