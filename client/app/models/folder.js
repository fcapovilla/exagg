import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  title: DS.attr('string'),
  open: DS.attr('boolean'),
  position: DS.attr('number'),
  feeds: DS.hasMany('feed', {async: true}),
  items: DS.hasMany('item', {async: true}),

  unreadCount: Ember.computed('feeds.@each.unreadCount', function() {
    return this.get('feeds').reduce(function(acc, feed) {
      return acc + feed.get('unreadCount');
    }, 0);
  })
});
