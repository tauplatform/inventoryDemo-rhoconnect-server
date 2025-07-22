# Use the official Ruby image matching the Gemfile version
FROM ruby:2.6.3

# Set the working directory in the container
WORKDIR /usr/src/app

# Install dependencies
# The base image comes with a compatible version of bundler.
# No need to install it again.

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Copy the .rcgemfile which is also needed
COPY .rcgemfile .rcgemfile

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
# The Procfile uses $PORT, which Heroku will set. We'll use a default for local running.
#EXPOSE 8080

# The command to run the application, from the Procfile
#CMD ["bundle", "exec", "thin", "start", "-p", "8080", "-e", "production"]