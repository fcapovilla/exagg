import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('folder');
  this.route('feed');
  this.route('item');
});

export default Router;
