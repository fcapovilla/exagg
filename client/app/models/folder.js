import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  title: DS.attr('string'),
  open: DS.attr('boolean', {defaultValue: true}),
  position: DS.attr('number'),
  feeds: DS.hasMany('feed', {async: false}),
  items: DS.hasMany('item', {async: true}),

  unreadCount: Ember.computed('feeds.@each.unreadCount', function() {
    return this.get('feeds').reduce(function(acc, feed) {
      return acc + feed.get('unreadCount');
    }, 0);
  }),

  feedSorting: ['position'],
  sortedFeeds: Ember.computed.sort('feeds', 'feedSorting')
});
