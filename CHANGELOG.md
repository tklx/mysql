## 0.1.0

Initial development release.

#### Notes

- Based off [tklx/base:0.1.1](https://github.com/tklx/base/releases/tag/0.1.1).
- MySQL installed directly from Debian.
- Uses tini for zombie reaping and signal forwarding.
- Includes ``VOLUME /var/lib/mysql`` for database persistence.
- Includes ``EXPOSE 3306`` for container linking.
- Basic bats testing suite.

