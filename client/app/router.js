import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('index', { path: '/' }, function() {
    this.route('folder', { resetNamespace: true, path: '/folder/:folder_id' });
    this.route('feed', { resetNamespace: true, path: '/feed/:feed_id' });
  });
});

export default Router;
