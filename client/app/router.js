import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('index', { path: '/' }, function() {
    this.route('items', {resetNamespace: true});
    this.route('favorites', {resetNamespace: true});
    this.route('folder', { resetNamespace: true, path: '/folder/:folder_id' });
    this.route('folder.edit', { resetNamespace: true, path: '/folder/:folder_id/edit' });
    this.route('feed', { resetNamespace: true, path: '/feed/:feed_id' });
    this.route('feed.edit', { resetNamespace: true, path: '/feed/:feed_id/edit' });
    this.route('feed.new', { resetNamespace: true, path: '/feed/new' });
  });
});

export default Router;
