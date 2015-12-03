import Ember from 'ember';
import InfinityRoute from 'ember-infinity/mixins/route';

export default Ember.Route.extend(InfinityRoute, {
  perPageParam: "page_size",

  model(params) {
    return Ember.RSVP.hash({
      folder: this.store.peekRecord('folder', params.folder_id),
      items: this.infinityModel('item', {perPage: 20, startingPage: 1, folder_id: params.folder_id})
    });
  },

  setupController(controller, model) {
    this._super(controller, model.items);
    this.controllerFor('index').set('selectedElement', model.folder);
  },

  renderTemplate: function(controller, model) {
    this.render('item-list', {
      model: model.items
    });
  }
});
