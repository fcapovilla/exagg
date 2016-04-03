import Ember from 'ember';

export default Ember.Controller.extend({
  application: Ember.inject.controller('application'),

  onIndex: function() {
    return (this.get('application.currentRouteName') === 'index.index');
  }.property('application.currentRouteName'),

  onItemList: function() {
    return (
      this.get('application.currentRouteName') === 'feed' ||
      this.get('application.currentRouteName') === 'folder' ||
      this.get('application.currentRouteName') === 'favorites' ||
      this.get('application.currentRouteName') === 'items'
    );
  }.property('application.currentRouteName')
});
